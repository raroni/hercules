dir = '../.././some/path/bingo'

parts = dir.split '/'

non_dots = parts.filter (p) -> p.substring(0, 1) != '.'

console.log non_dots


