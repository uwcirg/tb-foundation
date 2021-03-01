class HealthCheckSerializer < ActiveModel::Serializer

    attributes :status, :details, :description, :links

    def status
        return object.status ? "pass" : "fail"
    end

end