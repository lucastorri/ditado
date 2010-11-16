module Ditado
  
  module Util
    
    def self.read(file)
      open(file) do |f|
        return f.read
      end
    end
    
    def self.write(file, content)
      open(file, 'w') do |f|
        f.write content
      end
    end

  end
  
end