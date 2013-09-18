# encoding: utf-8

task default: :sane

desc 'Assert the sanity'
task sane: [:rubocop, :foodcritic]

desc 'Run rubocop'
task :rubocop do
  sh('rubocop --config .rubocop.yml --format simple') { |r, _| r || abort }
end

desc 'Run foodcritic'
task :foodcritic do
  sh('bundle exec foodcritic --epic-fail any .') { |r, _| r || abort }
end
