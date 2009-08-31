# Ledes
require "ledes/base"
require "ledes/ledes_file"
require "ledes/ledes_line"

Ledes::LedesFile.send(:include, Ledes::Base)
Ledes::LedesLine.send(:include, Ledes::Base)
