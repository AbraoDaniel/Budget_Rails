class Operation
  include ActiveModel::Model
  attr_accessor :id, :name, :amount, :operation_type, :created_at, :updated_at, :group_id, :author_id, :operation_id

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
      result = session.run("CREATE (o:Operation {name: $name, amount: $amount, operation_type: $operation_type, created_at: $created_at, updated_at: $updated_at, group_id: $group_id, author_id: $author_id, operation_id: $operation_id}) RETURN id(o)",
                           name: name, amount: amount, operation_type: operation_type, created_at: DateTime.now, updated_at: DateTime.now, group_id: group_id, author_id: author_id, operation_id: operation_id)
      @id = result.single[0]
    else
      session.run("MATCH (o:Operation) WHERE id(o) = $id SET o += {name: $name, amount: $amount, operation_type: $operation_type, created_at: $created_at, updated_at: $updated_at, group_id: $group_id, author_id: $author_id, operation_id: $operation_id}",
                  id: id, name: name, amount: amount, operation_type: operation_type, created_at: DateTime.now, updated_at: DateTime.now, group_id: group_id, author_id: author_id, operation_id: operation_id)
    end
    session.close
    self
  end

  def self.find(id)
    session = NEO4J_DRIVER.session
    begin
      query = "MATCH (o:Operation) WHERE id(o) = $id RETURN o"
      result = session.run(query, id: id)
      single_record = result.single
      operation = single_record[:o].properties.merge(id: single_record[:o].id)
      operation ? new(operation) : nil
    ensure
      session.close
    end
  end
  # Você precisará adaptar outros métodos que operam sobre a coleção de operações
end
