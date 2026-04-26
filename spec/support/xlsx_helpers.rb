module XlsxHelpers
  # Opens the binary string returned by Stradivari::XLSX::Generator and yields a
  # Roo::Excelx instance for assertions.
  def open_xlsx(binary)
    Tempfile.create(['stradivari', '.xlsx']) do |f|
      f.binmode
      f.write(binary)
      f.flush
      yield Roo::Excelx.new(f.path)
    end
  end

  def xlsx_rows(binary)
    rows = nil
    open_xlsx(binary) { |sheet| rows = sheet.parse }
    rows
  end
end
