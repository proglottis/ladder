guard 'minitest' do
  watch(%r|^test/minitest_helper\.rb|) { "test" }
  watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/controller/#{m[1]}_test.rb" }
  watch(%r|^app/controllers|)          { |m| "test/acceptance" }
  watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb|)      { |m| "test/unit/#{m[1]}_test.rb" }
end
