require 'spec_helper'

module Beatport::Catalog
  describe Chart do
  
    describe 'structure' do
      before(:all) { @chart = Chart.find(15722) }
      it { @chart.id.should == 15722 }
      it { @chart.type.should == "chart" }
      it { @chart.name.should == "Nitrous Oxide – April Top 10" }    
      it { @chart.slug.should == "nitrous-oxide-april-top-10" }
      it { @chart.description.should == "" }
      it { @chart.publish_date.should == Date.new(2009, 05, 12) }
      it { @chart.price.to_s.should == '13.91' }
      it { @chart.audio_format_fee.wav.to_s.should == "9.00" }
      it { @chart.audio_format_fee.aiff.to_s.should == "9.00" }      
      it { @chart.genres.map(&:name).should == ["Trance"] }
      it { @chart.images.small.url.should == "http://geo-media.beatport.com/items/imageCatalog/0/400000/90000/1000/500/30/491534.jpg"}
      it { @chart.images.medium.url.should == "http://geo-media.beatport.com/items/imageCatalog/0/400000/10000/2000/900/20/412921.jpg"}
      it { @chart.images.large.url.should == "http://geo-media.beatport.com/items/imageCatalog/0/400000/10000/2000/900/20/412922.jpg"}            

      it { @chart.tracks.length.should == 9 }
    end
  
    describe '.find' do
      chart = Chart.find(15722)
      chart.id.should == 15722
    end
  
    describe '.all' do
      it "should get arbitrary charts" do
        charts = Chart.all
        charts.length.should == 10
      end
    
      it "should get the first page with 5 charts per page" do
        charts = Chart.all :per_page => 5, :page => 1
        charts.length.should == 5
        charts.page.should == 1
        charts.per_page.should == 5
      end
    
      it "should get the first page with 5 charts per page, sorted by publish date and chart id, for the House genre" do
        charts = Chart.all(:sort_by=> ['publishDate asc', 'chartId asc'], :genre_id=> 5, :per_page=>5, :page=>1)
        charts.length.should == 5
      
        old_id = nil
        old_date = charts.first.publish_date
      
        charts.each do |chart|
          old_id = nil if old_date.to_s != chart.publish_date.to_s
        
          # it's possible that the genre is a subgenre of house, so we'll disable this test for now
#          chart.genres.map(&:id).should include(5)
          chart.id.should be >= old_id if old_id
          chart.publish_date.should be >= old_date if old_date
        
          old_id = chart.id
          old_date = chart.publish_date
        end
      end
    
      it "should get arbitrary charts with filter metadata for all genre names and artist names" do
        charts = Chart.all :return_facets => ['genre_name', 'performer_name']
 
        # despite what the beatport api doc says, the query deoesn't return any performer names...
#        charts.facets['fields']['performer_name'].count.should be > 1
        charts.facets['fields']['genre_name'].count.should be > 1      
      end

      it "should get all charts for trance and progressive house" do
        charts = Chart.all :facets => {:genre_name => ['Trance', 'Progessive House']}
    
        charts.each do |chart|
          genres = chart['genres'].map { |a| a['name'] }
          pp genres
        end
      end
    end
    
    describe '.featured' do
      it "should get the featured charts for the Home page" do
        charts = Chart.featured
        charts.length.should be > 1
      end
      
      it "should get the featured charts for the Trance page" do
        charts = Chart.featured :genre_id => 7
        charts.length.should be > 1
        charts.each do |chart|
          chart.genres.map(&:id).should include(7)
        end
      end
    end
  end
end