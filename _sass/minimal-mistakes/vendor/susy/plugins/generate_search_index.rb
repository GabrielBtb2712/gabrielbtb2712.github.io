module Jekyll
    class SearchIndexGenerator < Generator
      safe true
  
      def generate(site)
        index = []
  
        site.posts.docs.each do |post|
          index << {
            "title" => post.data["title"],
            "content" => post.content,
            "url" => post.url
          }
        end
  
        File.write("search-index.json", index.to_json)
      end
    end
  end