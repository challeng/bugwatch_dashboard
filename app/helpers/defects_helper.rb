module DefectsHelper

  def graph_grouped_values(releases, defects)
    grouped_defects = grouped_by_release(releases, defects)
    [
        {"name" => "Open", "data" => grouped_defects.map {|_, defects| defects.count(&:open?) }},
        {"name" => "Closed", "data" => grouped_defects.map {|_, defects| defects.count(&:closed?) }}
    ].to_json
  end

  def grouped_by_release(releases, defects)
    releases_enum = releases.to_enum
    {}.tap do |hsh|
      loop do
        release = releases_enum.next
        next_release = releases_enum.peek rescue Release.new(deploy_date: DateTime.now)
        hsh[release] = defects.select do |defect|
          (release.deploy_date..next_release.deploy_date - 1.second).cover? defect.date
        end
      end
    end
  end

end
