require "pg"
  
class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "spending")
  end
  
  def new_payment(payment, category)
    sql = "INSERT INTO payments(amount, category) VALUES ($1, $2);"
    
    @db.exec_params(sql, [payment, category])
  end
  
  def new_payment_with_date(amount, date, category)
    sql = "INSERT INTO payments(amount, date, category) VALUES ($1, TIMESTAMP $2, $3)"
    
    @db.exec_params(sql, [amount, date, category])
  end
  
  def display_payments
    sql = "SELECT * FROM payments;"
    
    @db.exec_params(sql)
  end
  
  def total
    sql = "SELECT SUM(CAST(amount AS float)) FROM payments;"
   
    @db.exec_params(sql)
  end
  
  def payments_for_category(category)
    sql = "SELECT * FROM payments WHERE category = $1;"
    
    @db.exec_params(sql, [category])
  end
  
  def payments_for_month(month, year)
    sql = "SELECT * FROM payments WHERE CAST(date_of_payment AS text) LIKE CONCAT('%', $1::text, '%') AND CAST(date_of_payment AS text) LIKE CONCAT($2::text, '%');"
    
    @db.exec_params(sql, [month, year])
  end
  
  def total_for_category(category)
    sql = "SELECT am FROM payments GROUP BY category HAVING category = $1;"
    
    @db.exec_params(sql, [category])
  end
  
  def find_payment_id(amount, category, date)
    sql = "SELECT id FROM payments WHERE amount=$1 AND category=$2 AND date_of_payment=$3"
    
    @db.exec_params(sql, [amount, category, date])
  end 
  
  def delete_payment(id)
    sql = "DELETE FROM payments WHERE id = $1"
    
    @db.exec_params(sql, [id])
  end
  
  def amounts
    sql = ("SELECT amount FROM payments")
    
    @db.exec_params(sql)
  end
  
  def amounts_for_category(category)
    sql = ("SELECT amount FROM payments WHERE category=$1")
    
    @db.exec_params(sql, [category])
  end
end