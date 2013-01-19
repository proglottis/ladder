guard 'minitest' do
  watch(%r|^test/minitest_helper\.rb|) { "test" }
  watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/acceptance/#{m[1]}_test.rb" }
  watch(%r|^app/views/(.*)/|)          { |m| ["test/acceptance/#{m[1]}_controller_test.rb", "test/mailers/#{m[1]}_test.rb"] }
  watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb|)      { |m| "test/models/#{m[1]}_test.rb" }
end
