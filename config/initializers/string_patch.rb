class String

  #为String 类添加一个格式前后空白的方法.主要是用在搜索的地方
 def format_key
    str = self.lstrip.rstrip

    str
  end 
end