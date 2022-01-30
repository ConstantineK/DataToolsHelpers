function Expand-SqlScript {
    param ($DocumentString)
    #Write-Debug "Expand-SqlFile $DocumentString"

    $badvalues = @( $null, '' )
    if ($DocumentString -in $badvalues) {
        throw "Script is null or blank, please provide a valid file."
    }

    function Export-SqlCodeWithoutComments {
        param (
                $SqlStatement, $preservePositions, $removeLiterals = $false
        )
        Write-Debug "Export-SqlCodeWithoutComments"
        $everythingExceptNewLines = [Regex]"[^\r\n]";
        # Based on http://drizin.io/Removing-comments-from-SQL-scripts/ and converted by Constantine Kokkinos
        # Which was based on http://stackoverflow.com/questions/3524317/regex-to-strip-line-comments-from-c-sharp/3524689#3524689
        $lineComments = "--(.*?)\r?\n";
        $lineCommentsOnLastLine = "--(.*?)$" # because it's possible that there's no \r\n after the last line comment
        # literals ('literals'), bracketedIdentifiers ([object]) and quotedIdentifiers ("object"), they follow the same structure:
        # there's the start character, any consecutive pairs of closing characters are considered part of the literal/identifier, and then comes the closing character
        $literals = "('(('')|[^'])*')" # 'John', 'O''malley''s', etc
        $bracketedIdentifiers = "\[((\]\])|[^\]])* \]" # [object], [ % object]] ], etc
        $quotedIdentifiers = "(\""((\""\"")|[^""])*\"")" # "object", "object[]", etc - when QUOTED_IDENTIFIER is set to ON, they are identifiers, else they are literals
        # var blockComments = @"/\*(.*?)\*/";  //the original code was for C#, but Microsoft SQL allows a nested block comments // //https://msdn.microsoft.com/en-us/library/ms178623.aspx
        # so we should use balancing groups // http://weblogs.asp.net/whaggard/377025
        $nestedBlockComments = "/\*
                                    (?>
                                    /\*  (?<LEVEL>)      # On opening push level
                                    |
                                    \*/ (?<-LEVEL>)     # On closing pop level
                                    |
                                    (?! /\* | \*/ ) . # Match any char unless the opening and closing strings
                                    )+                         # /* or */ in the lookahead string
                                    (?(LEVEL)(?!))             # If level exists then fail
                                    \*/";
        $noComments = [Regex]::Replace(
            $SqlStatement,
            $nestedBlockComments + "|" + $lineComments + "|" + $lineCommentsOnLastLine + "|" + $literals + "|" + $bracketedIdentifiers + "|" + $quotedIdentifiers,
            {
                if ($args[0].Value.StartsWith("/*") -and $preservePositions){
                    return $everythingExceptNewLines.Replace($args[0].Value, " ")
                }# preserve positions and keep line-breaks // return new string(' ', me.Value.Length);
                elseif ($args[0].Value.StartsWith("/*") -and !$preservePositions){
                    return "";
                }
                elseif ($args[0].Value.StartsWith("--") -and $preservePositions){
                    return $everythingExceptNewLines.Replace($args[0].Value, " ")
                }# preserve positions and keep line-breaks
                elseif ($args[0].Value.StartsWith("--") -and !$preservePositions){
                    return $everythingExceptNewLines.Replace($args[0].Value, "")
                }# preserve only line-breaks // Environment.NewLine;
                elseif ($args[0].Value.StartsWith("[") -or $args[0].Value.StartsWith("\`"")){
                    return $args[0].Value # do not remove object identifiers ever
                }
                elseif (!$removeLiterals){ # Keep the literal strings
                    return $args[0].Value;
                }
                elseif ($removeLiterals -and $preservePositions){ # remove literals, but preserving positions and line-breaks
                $literalWithLineBreaks = $everythingExceptNewLines.Replace($args[0].Value, " ");
                    return "'" + $literalWithLineBreaks.Substring(1, $literalWithLineBreaks.Length - 2) + "'";
                }
                elseif ($removeLiterals -and !$preservePositions){ # wrap completely all literals
                    return "''";
                }
                else {
                    throw NotImplementedException;
                }
            },
            [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnorePatternWhitespace);
        return $noComments;
    }

    $CommentDataRemoved = Export-SqlCodeWithoutComments -SqlStatement $DocumentString

    # Breaks on GO isolated on its own line after all comments have been removed.
    # If you dont have GOs on their own line, you are not canonical, fix your code.
    $GoStatements = '(?ms)[\s^][gG][oO][\s$]'
    $querylist = , $CommentDataRemoved -Split $GoStatements

    $querylist = $querylist | Where-Object {$_} # Remove blanks
	if ($null -ne $querylist -and $querylist.trim() -ne '') {
		Write-Debug "Returning $(($querylist | Measure-Object).count) queries"
		return , $querylist
	}
}