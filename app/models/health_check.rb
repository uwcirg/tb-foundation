class HealthCheck < ActiveModelSerializers::Model
    
    def status
        return redis_connected? && postgres_connected? && minio_connected?
    end

    def description
        "Health of the backend services for the TB project"
    end

    def details
        {
            "redis:connection": display_status(redis_connected?),
            "postgres:connection": display_status(postgres_connected?),
            "minio:connection": display_status(minio_connected?)
        }

    end

    def links
        {
            response_format: "https://tools.ietf.org/id/draft-inadarei-api-health-check-01.html"
        }
    end

    def postgres_connections
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
        Aws::S3::Resource.new(retry_limit: 0).bucket("patient-test-photos").exists? rescue false
    end

    def display_status(pass)
        return [{ status: pass ? "pass" : "fail"}]
    end



end
