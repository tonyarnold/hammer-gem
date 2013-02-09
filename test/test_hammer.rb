require "./tests"

class TestHammer < Test::Unit::TestCase
  context "Hammer"  do
    should "find the right parser" do
      assert_equal Hammer.parser_for_extension("html"), Hammer::HTMLParser
    end
    
    should "perform clever path matching" do
      assert "index.html".match     Hammer.regex_for("index", "html")
      assert "about.html".match     Hammer.regex_for("*", "html")
      assert "assets/app.js".match  Hammer.regex_for("/*", "js")
      assert "assets/app.js".match  Hammer.regex_for("/assets/*", "js")
      assert "assets/app.js".match  Hammer.regex_for("assets/*", "js")

      assert !("index.html".match(Hammer.regex_for("*", "js")))
      assert ("logo.png".match(Hammer.regex_for("logo.png")))
      
      # Test all the combinations! 
      # Remember, match x against y with extension z.
      def match(filename, tag, extension=nil)
        filename.match Hammer.regex_for(tag, extension)
      end
      
      assert match "index.html", "/index", "html"
      assert match "index.html", "index", "html"
      assert match "index.html", "*", "html"
      assert match "assets/javascript.js", "*", "js"
      assert match "assets/javascript.js", "assets/*", "js"
      assert match "index.html", "/index", "html"
      assert match "index.html", "/index", "html"
      assert match "index.html", "/*", "html"
      assert match "assets/_header.html", "_header", "html"
      assert match "logo.png", "logo.png"
      assert match "assets/style.scss", "style", 'scss'
      assert !match("index.html", "*", "js")
      assert !match("/assets/index.html", "*", "css")
    end
  end
  
end