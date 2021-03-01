class HealthCheck < ActiveModelSerializers::Model
    
    def status
        return redis_connected? && postgres_connected?
    end

    def db_connections
        ActiveRecord::Base.connection_pool.connections.size
    end

    private

    def redis_connected?
        !!Sidekiq.redis(&:info) rescue false
    end

    def postgres_connected?
        ActiveRecord::Base.connected? rescue false
    end

    def minio_connected?
        Aws::S3::Resource.new.bucket("patient-test-photos").exists? rescue false
    end



end
