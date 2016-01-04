class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	def get_agreement
		st = ActiveRecord::Base.connection
		res = st.execute('SELECT u1.id user1_id,u2.id user2_id, (count(*)*1.0)/(SELECT count(*) FROM assoziations WHERE user_id=u2.id) as agreement
			FROM users u1, users u2, assoziations ass1, assoziations ass2
			WHERE u1.id=' + self.id.to_s + ' AND u2.id != u1.id
			AND ass1.user_id = u1.id
			AND ass2.user_id = u2.id
			AND ass1.ding_eins_id=ass2.ding_eins_id
			AND ass1.ding_zwei_id=ass2.ding_zwei_id GROUP BY u1.id,u2.id ORDER BY agreement DESC')
		st.close()
		return res
	end

	def get_new_associations(other_user_id=nil)
		if other_user_id.nil?			
			st = ActiveRecord::Base.connection
			res = st.execute('SELECT ding_eins_id,ding_zwei_id,count(*) as count_id FROM 
					(SELECT ass.*
					FROM assoziations ass
					WHERE ass.user_id!=' + self.id.to_s + ') ass1
				WHERE NOT EXISTS (
					SELECT ding_eins_id,ding_zwei_id
					FROM assoziations ass
					WHERE ass.user_id=' + self.id.to_s + '
					AND ass.ding_eins_id = ass1.ding_eins_id
					AND ass.ding_zwei_id = ass1.ding_zwei_id
				) GROUP BY ding_eins_id, ding_zwei_id ORDER BY count_id DESC;')
			st.close()
			return res
		else
			st = ActiveRecord::Base.connection
			res = st.execute('SELECT ding_eins_id,ding_zwei_id,count(*) as count_id FROM 
					(SELECT ass.*
					FROM assoziations ass
					WHERE ass.user_id=' + other_user_id.to_s + ') ass1
				WHERE NOT EXISTS (
					SELECT ding_eins_id,ding_zwei_id
					FROM assoziations ass
					WHERE ass.user_id=' + self.id.to_s + '
					AND ass.ding_eins_id = ass1.ding_eins_id
					AND ass.ding_zwei_id = ass1.ding_zwei_id
				) GROUP BY ding_eins_id, ding_zwei_id ORDER BY count_id DESC;')
			st.close()
			return res
		end
	end
end
