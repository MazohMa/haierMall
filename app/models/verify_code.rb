class VerifyCode < ActiveRecord::Base

  after_create :send_message

  def send_message
    if self.op == 'register'
      Util::Tool.send_message(self.mobile, "您注册的验证码为: #{self.code}, 请尽快注册【海尔】")
    elsif self.op == 'reset_password'
      Util::Tool.send_message(self.mobile, "您重置密码的验证码为: #{self.code}, 请尽快重置密码【海尔】")
    end
  end
end
