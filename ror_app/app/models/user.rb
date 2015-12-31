class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	def get_agreement
		other_user_id = 2
		st = ActiveRecord::Base.connection
		res = st.execute('SELECT u1.id user1_id,u2.id user2_id, (count(*)*1.0)/(SELECT count(*) FROM assoziations WHERE user_id=u2.id) as agreement
			FROM users u1, users u2, assoziations ass1, assoziations ass2
			WHERE u1.id=' + self.id.to_s + ' AND u2.id != u1.id
			AND ass1.user_id = u1.id
			AND ass2.user_id = u2.id
			AND ass1.ding_eins_id=ass2.ding_eins_id
			AND ass1.ding_zwei_id=ass2.ding_zwei_id GROUP BY u1.id,u2.id')
		st.close()
		#res = Assoziation.find_by_sql()
		#res = res.to_f / Assoziation.where(:user_id => other_user_id).count
		return res
	end
end
