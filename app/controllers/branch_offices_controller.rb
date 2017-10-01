class BranchOfficesController < ApplicationController

  def index
  end



  def get_by_location

    regions = Hash.new

    offices = BranchOffice.all.includes({ :comuna => :region })

    offices.each do |o|
      comuna = o.comuna.name
      region = o.comuna.region.name
      address = o.address
      if !regions.has_key? region
        regions[region] = {}
      end
      if !regions[region].has_key? comuna
        regions[region][comuna] = []
      end
      regions[region][comuna] << { address: address, id: o.id }
    end

    render :json => regions.as_json, :status => :ok

  end



end
