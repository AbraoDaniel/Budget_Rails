class Operation
  include ActiveModel::Model
  attr_accessor :id, :name, :amount, :operation_type, :created_at, :group_id, :author_id

  # Inicializador com valores padrões para atributos
  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    @created_at ||= DateTime.now
  end

  def save
    session = NEO4J_DRIVER.session
    if id.nil?
      result = session.run("CREATE (o:Operation {name: $name, amount: $amount, operation_type: $operation_type, created_at: $created_at, group_id: $group_id, author_id: $author_id}) RETURN id(o)",
                           name: name, amount: amount, operation_type: operation_type, created_at: DateTime.now, group_id: group_id, author_id: author_id)
      @id = result.single[0]
    else
      session.run("MATCH (o:Operation) WHERE id(o) = $id SET o += {name: $name, amount: $amount, operation_type: $operation_type, created_at: $created_at, group_id: $group_id, author_id: $author_id}",
                  id: id, name: name, amount: amount, operation_type: operation_type, created_at: DateTime.now, group_id: group_id, author_id: author_id)
    end
    session.close
    self
  end

  def self.find(id)
    session = NEO4J_DRIVER.session
    result = session.run("MATCH (o:Operation) WHERE id(o) = $id RETURN o", id: id)
    operation = result.single&.[](:o)&.properties&.merge(id: result.single[:o].id)
    session.close
    operation ? new(operation) : nil
  end

  # Você precisará adaptar outros métodos que operam sobre a coleção de operações
end
