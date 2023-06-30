require "pg"

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "slanders")
  end
  
  def show_all_slanders 
    sql = "SELECT username, paragraph, date_created FROM slanders INNER JOIN users ON users.id = slanders.username_id ORDER BY slanders.id DESC"
    @db.exec_params(sql)
  end
  
  def slanders_for_profile(username)
    sql = "SELECT username, paragraph, date_created FROM slanders INNER JOIN users ON users.id = slanders.username_id WHERE username = $1 ORDER BY slanders.id DESC"
    @db.exec_params(sql, [username])
  end
  
  def create_new_slander(slander_text, name_id)
    sql = "INSERT INTO slanders(paragraph, username_id) VALUES ($1, $2)"
    @db.exec_params(sql, [slander_text, name_id])
  end
  
  def username_to_username_id(username)
    sql = "SELECT DISTINCT id FROM users WHERE username = $1"
    result = @db.exec_params(sql, [username])
    
    result.map do |tuple|
      tuple["id"]
    end[0].to_i
  end
  
  def delete_slander(paragraph)
    sql = "DELETE FROM slanders WHERE paragraph = $1"
    db.exec_params(sql, [paragraph])
  end
  
  def valid_username?(username)
    
  end
end