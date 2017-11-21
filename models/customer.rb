require_relative('../db/sql_runner')
require_relative('./film')

class Customer
  attr_accessor :name, :fund
  attr_reader :id

  def initialize(options)
    @name = options['name']
    @fund = options['fund'].to_i
    @id = options['id'].to_i if options['id']
  end

  def save()
    sql = "INSERT INTO customers
    (
      name,
      fund
    ) VALUES
    (
      $1, $2
    ) RETURNING *"
    values = [@name, @fund]
    customer = SqlRunner.run(sql, values).first
    @id = customer['id'].to_i
  end

  def tickets_bought()
    return films().count
  end

  def films()
    sql = "SELECT films.*
    FROM films
    INNER JOIN tickets
    ON tickets.film_id = films.id
    WHERE tickets.customer_id = $1"
    values = [@id]
    film_data = SqlRunner.run(sql, values)
    return film_data.map{|film| Film.new(film) }
  end



  def self.all
    sql = "SELECT * FROM customers"
    customers = SqlRunner.run(sql)
    return customers.map {|customer| Customer.new(customer)}
  end

  def self.delete_all()
    sql = "DELETE FROM customers"
    values = []
    SqlRunner.run(sql, values)
  end

end
