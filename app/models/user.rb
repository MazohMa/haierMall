class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable
  #       :recoverable, :rememberable, :trackable, :validatable
  #
  has_one :session, dependent: :destroy
  has_one :dealer, dependent: :destroy
  has_one :shop_owner, dependent: :destroy
  has_one :admin_message, dependent: :destroy
  has_many :cart_records ,dependent: :destroy
  has_many :user_get_coupon_informations
  has_many :user_authorization_pics ,dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :member, dependent: :destroy
  has_one :user_subscribe, dependent: :destroy
  has_many :integration_records, dependent: :destroy
  has_many :credit_records, dependent: :destroy
  has_many :user_exchange_products, dependent: :destroy
  has_many :access_authorities, dependent: :destroy
  has_many :user_coupon_packages, dependent: :destroy

  validates :mobile, :password, :presence => true, :on => :create
  validates :mobile, :numericality => true, format:{ :with=>/\A1[3|4|5|7|8]\d{9}\Z/}
  validates_format_of :email, :allow_blank => true, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => '格式不正确'
  validates_length_of :password, :minimum => 6, :maximun => 12, :allow_blank => true
  validates_uniqueness_of :mobile

  after_create :default_username,:create_member
  after_save :daily_sign_to_get_growth, :create_ability

  alias_method :db_session, :session
  alias_method :db_member, :member

  def as_json(options = {})
    if self.role == 'dealer'
      dealer_as_json
    #elsif self.role == 'shop_owner'
      #shop_owner_as_json
    else
      shop_owner_as_json
    end
  end

  def shop_owner_as_json
    {:id => self.id, :mobile => self.mobile, :token => self.session.token, :status => user_state(self.string), :role => self.role}
  end

  def dealer_as_json
    {:id => self.id, :mobile => self.mobile, :company_name => ((d = self.dealer).nil? ? nil : d.company_name), :token => self.session.token, :status => user_state(self.string), :role => self.role}
  end

  def session
    @session ||= ((s = self.db_session).nil? ? Session.create_with_user_id(self.id) : s)
  end

  def member
    @member ||= ((member = self.db_member).nil? ? Member.create(:user_id => self.id, :level => 'V0', :integration => 0, :used_integration => 0, :amount => 0.0) : member )
  end
  
  def user_state(string)
    state = 0
    if string != nil
      state = 2 if string == "审核通过"
      state = 1 if string == "待审核" || string == "待审"
      state = 3 if string == "审核不通过"
    end
    return state
  end

  def default_username
    self.username = self.mobile
    self.save
  end

  def update_session(channel_id, baidu_user_id)
    self.session = Session.new(:user_id => self.id) if self.session.nil?
    self.session.token = Util::Tool.generate_key
    self.session.channel_id = channel_id
    self.session.baidu_user_id = baidu_user_id
    # self.session.platform = platform
    # self.session.tag = self.role
    self.session.save
  end

  #每日首次登陆所获成长值
  def daily_sign_to_get_growth
    if self.get_growth_time.blank? or (self.current_sign_in_at.present? and self.current_sign_in_at.strftime("%Y-%m-%d") != self.get_growth_time.strftime("%Y-%m-%d"))
      growthrule = GrowthRule.where("rule_type = ? ", 3).first
      if growthrule.present? and growthrule.is_used == true
        self.member.change_and_update_growth(growthrule.growth_value)  #更新会员成长值,等级
        self.get_growth_time = Time.new
        self.save
        #添加成长值记录。record_type = 1是交易额 ，2是评价订单， 3是每日登陆
        GrowthRecord.create(:user_id => self.id, :record_type => 3, :description => "每日登陆", :growth => growthrule.growth_value)
      end
    end
  end

  def create_member
    if Member.find_by_user_id(self.id).blank?
      Member.create(:user_id => self.id, :level => 'V0', :integration => 0, :used_integration => 0, :amount => 0.0)
    end
  end
  
  def create_ability
    if (self.access_authority_id.blank? || self.owner_id.blank?)  && self.role == "dealer"
      admin = User.where("owner_id = id and role = 'admin'").first
      self.access_authority_id = admin.access_authorities.find_by_name("dealer").id
      self.owner_id = admin.id
      self.save
    elsif (self.access_authority_id.blank? || self.owner_id.blank?) && self.string == "审核通过" && self.role == "shop_owner"
      admin = User.where("owner_id = id and role = 'admin'").first
      self.access_authority_id = admin.access_authorities.find_by_name("shop_owner").id
      self.owner_id = admin.id
      self.save
    end
  end

  def last_admin_message
    AdminMessage.where(:user_id => self.id).last
  end

end
