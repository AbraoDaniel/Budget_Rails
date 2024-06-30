# config/initializers/neo4j.rb
require 'neo4j_ruby_driver'

NEO4J_DRIVER = Neo4j::Driver::GraphDatabase.driver(
  'bolt://127.0.0.1:7689', 
  Neo4j::Driver::AuthTokens.basic('neo4j', 'danielrails')
)
