module Backstage::CollocationsHelper
  def get_status_text(collocations)
    status = collocations.status.to_i
    if status==0
      return '未进行'
    end

    if status==1
      return '火热进行中'
    end

    if status==2
      return '已失效'
    end
  end

  def get_status_style(collocations)
    status = collocations.status.to_i
    if status==0
      return 'state-standby'
    end

    if status==1
      return 'state-valid'
    end

    if status==2
      return 'state-invalid'
    end
  end
end
