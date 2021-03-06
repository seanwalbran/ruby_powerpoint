require 'ruby_powerpoint'

describe 'RubyPowerpoint trying to parsing an invalid file.' do
  it 'not open an XLS file successfully.' do
    lambda { RubyPowerpoint::Presentation.new 'specs/fixtures/invalid.xls' }.should raise_error 'Not a valid file format.'
  end
end

describe 'RubyPowerpoint parsing a sample PPTX file' do
  before(:all) do
    @deck = RubyPowerpoint::Presentation.new 'spec/fixtures/sample.pptx'
  end

  after(:all) do
    @deck.close
  end

  it 'parse a PPTX file successfully.' do
    @deck.should_not be_nil
    @deck.slides.should_not eql []
    @deck.slides.first.content.should eql ["Some test ", "Powerpoint"]
    @deck.slides.first.content.should eql  ["Some test ", "Powerpoint"]
    image_byte_stream_1 = @deck.slides.first.images.first.read
    File.open('temp_1.jpg', 'w'){|f| f.puts image_byte_stream_1}

    @deck.slides.first.images.first.should_not eql nil #"ppt/media/image1.jpeg"
    @deck.slides.last.title.should eql "Some title here"
    @deck.slides.last.content.should eql ["Some title here", "Some txt here", "Some ", "more text here."]
    image_byte_stream_2 = @deck.slides.last.images.first.read
    File.open('temp_2.jpg', 'w'){|f| f.puts image_byte_stream_2}
  end

  it "it parses Slide Notes of a PPTX  slides" do
    notes_content = @deck.slides[0].notes_content
    notes_content.should eql ["Testing", " Multiline Notes.", "To be extracted here.", "Multiline notes extracted.", "1"]
  end

end

describe 'open rime.pptx file' do
  before(:all) do
    @deck = RubyPowerpoint::Presentation.new 'spec/fixtures/rime.pptx'
  end

  after(:all) do
    @deck.close
  end

  it 'opened rime.pptx successfully' do
    @deck.should_not be_nil
    @deck.slides.should_not eql []
  end

  it 'should have the right number of slides' do
    @deck.slides.length.should eql 12
  end

  it 'the old content method should work the same way' do
    @deck.slides[0].content.should eql ["The Rime of the Ancient Mariner", "(text of 1834)", "http://rpo.library.utoronto.ca/poems/rime-ancient-mariner-text-1834"]
  end

  context 'the titles should be right' do
    it 'should be able to get a main slide (usually centered)' do
      @deck.slides[0].title.should eql "The Rime of the Ancient Mariner"
    end
    it 'should be able to get regular slide titles' do
      @deck.slides[1].title.should eql "Argument"
      @deck.slides[2].title.should eql "PART I"
      @deck.slides[3].title.should eql "PART II"
      @deck.slides[4].title.should eql "Part III"
      @deck.slides[8].title.should eql "There's more"
    end
    it 'should return nil if the slide has no title' do
      @deck.slides[5].title.should be_nil
      @deck.slides[6].title.should be_nil
    end

    it 'should only get one title even if there are two things that visually look like titles' do
      @deck.slides[7].title.should eql "What if we have two"
    end

    context 'when slide contains paragraph' do
      before(:all) do
        @slide = @deck.slides[1]
      end

      it 'should return the list of paragraphs' do
        @slide.paragraphs.count.should eql 2
      end

      it 'should return the content of the paragraph' do
        @slide.paragraphs[0].content.should eq ['Argument']
      end
    end
  end
end
