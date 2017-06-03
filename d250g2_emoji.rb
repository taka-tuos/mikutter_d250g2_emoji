# -*- coding: utf-8 -*-

Plugin.create(:d250g2) do
  begin
    @reply_array = YAML.load_file(File.join(__dir__, 'config.yml'))
  rescue LoadError
    notice '"config.yml" not found.'
  end

  command(:d250g2,
          name: 'd250g2-emoji',
          condition: Plugin::Command[:CanReplyAll],
          visible: true,
          role: :timeline) do |m|
    m.messages.map do |msg|
      emoji(msg.message)
    end
  end

  def emoji(m)
    id = m.idname
    message = "@#{id}"
    filename = @reply_array.sample
    Thread.new {
      m.post(message: message,
             mediaiolist: [File.new(File.join(__dir__, 'emoji', filename))])
    }.trap { |err|
      error err
    }
  end
end
