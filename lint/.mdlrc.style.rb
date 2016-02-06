all

exclude_rule 'MD013' # Line length
exclude_rule 'MD024' # Multiple headers with the same content TODO: 有効にしたいがちょいちょいあるので
exclude_rule 'MD029' # Ordered list item prefix
exclude_rule 'MD033' # Inline HTML
exclude_rule 'MD040' # Fenced code blocks should have a language specified

rule 'MD007', :indent => 4 # Unordered list indentation
rule 'MD009', :br_spaces => 2 # Trailing spaces
rule 'MD026', :punctuation => ",;" # Trailing punctuation in header
