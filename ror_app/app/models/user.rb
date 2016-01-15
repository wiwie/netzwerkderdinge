class User < ActiveRecord::Base
	has_many :favorits
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :user_assoziations

	def get_agreement
		st = ActiveRecord::Base.connection
		res = st.execute('SELECT u1.id user1_id,u2.id user2_id, (count(*)*1.0)/(SELECT count(*) FROM user_assoziations WHERE user_id=u2.id) as agreement
			FROM users u1, users u2, user_assoziations ass1, user_assoziations ass2
			WHERE u1.id=' + self.id.to_s + ' AND u2.id != u1.id
			AND ass1.user_id = u1.id
			AND ass2.user_id = u2.id
			AND ass1.assoziation_id=ass2.assoziation_id GROUP BY u1.id,u2.id ORDER BY agreement DESC')
		st.close()
		return res
	end

	def get_new_associations(other_user_id=nil, order_by='count_id')
		if other_user_id.nil?			
			st = ActiveRecord::Base.connection
			res = st.execute('SELECT assoziation_id,count(*) as count_id,created_at FROM 
					(SELECT *
					FROM user_assoziations
					WHERE user_id!=' + self.id.to_s + ') ass1
				WHERE assoziation_id NOT IN (
					SELECT assoziation_id
					FROM user_assoziations
					WHERE user_id=' + self.id.to_s + '
					AND assoziation_id = ass1.assoziation_id
					AND published
				) GROUP BY assoziation_id ORDER BY ' + order_by + ' DESC;')
			st.close()
			return res
		else
			st = ActiveRecord::Base.connection
			res = st.execute('SELECT assoziation_id,count(*) as count_id,created_at FROM 
					(SELECT *
					FROM user_assoziations
					WHERE user_id=' + other_user_id.to_s + ') ass1
				WHERE assoziation_id NOT IN (
					SELECT assoziation_id
					FROM user_assoziations
					WHERE user_id=' + self.id.to_s + '
					AND assoziation_id = ass1.assoziation_id
					AND published
				) GROUP BY assoziation_id ORDER BY ' + order_by + ' DESC;')
			st.close()
			return res
		end
	end
end
