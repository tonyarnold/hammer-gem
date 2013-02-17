require "tests"

class CSSParserTest < Test::Unit::TestCase
  context "A CSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::CSSParser.new(@hammer_project)
    end
    
    should "exist" do
      assert @parser
    end
    
    should "parse url iamges" do
      font = Hammer::HammerFile.new()
      font.filename = "images/proximanova-regular.eot"
      @hammer_project << font
      
      @css_file = Hammer::HammerFile.new()
      @css_file.filename = "style.css"
      @parser.hammer_file = @css_file
      @parser.text = "a { background: url(proximanova-regular.eot?#iefix) }"
      assert_equal "a { background: url(images/proximanova-regular.eot?#iefix) }", @parser.parse()
    end
    
    context "with a CSS file" do
      
      setup do
        @file = Hammer::HammerFile.new
        @file.filename = "style.css"
        @parser.hammer_file = @file
        @file.raw_text = "a {background: red}"
      end
      
      should "parse CSS" do
        @parser.text = @file.raw_text
        assert_equal @file.raw_text, @parser.parse()
      end
      
      context "with other files" do
        
        setup do
          @new_file = Hammer::HammerFile.new
          @new_file.raw_text = "I'm included."
          @new_file.filename = "assets/_include.css"
          @hammer_project << @new_file
        end

        def assert_compilation(pre, post)
          @parser.text = pre
          assert_equal @parser.parse(), post
        end
        
        should "do paths" do
          assert_compilation "url(_include.css);", "url(assets/_include.css);"
        end

        should "do stupid relative paths" do
          assert_compilation "url(../../_include.css);", "url(assets/_include.css);"          
        end

        should "not do http paths" do
          assert_compilation "url(http://bullshit.png);", "url(http://bullshit.png);"          
        end

        should "not do https paths" do
          assert_compilation "url(https://bullshit.png);", "url(https://bullshit.png);"          
        end        

        should "not change query paths with unknown files" do
          assert_compilation "url(bullshit.png?a);", "url(bullshit.png?a);"          
        end
        
        should "do data:png paths" do
          assert_compilation "url(data:image/png;base64,123)", "url(data:image/png;base64,123)"
        end
        
        should "do include" do
          assert_compilation "/* @include _include */", "I'm included."
        end
      end
    end
  end
end
