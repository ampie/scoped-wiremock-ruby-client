describe 'Scratchy' do
  class Boo
    def to_s
      'hello'
    end

  end
  it 'should sadf' do
    uri= URI.parse('http://user:pwd@host/path/path/file.rb?var1=0;var2=1')
    puts(uri.scheme + '::/' + uri.host + ':' + uri.port.to_s)
  end
end
