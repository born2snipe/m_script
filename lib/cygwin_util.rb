
module MScript 
  class CygwinUtil
    def fix_path(path) 
      path.gsub(/\/cygdrive\/(.)\/(.*)/, '\1:/\2')
    end
  end
end