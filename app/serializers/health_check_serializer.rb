class HealthCheckSerializer < ActiveModel::Serializer

    attributes :status, :db_connections

end