local args = {...}
local fs = require('filesystem')
if not args[1] and not args[2] and not args[3] then
  print('Usage:')
  print('At first argument you choose mode of work:')
  print('h -- host file')
  print('r -- request file')
  print('At second argument you choose output file or file to host')
  print('At third argument you choose name of your host/ name of request who host')
  return nil
end
pcall(function() lfr = require('lfr') end)
if not lfr then
  print('Download lfr lib, https://github.com/0leshe/lfr')
end
if args[1] == 'h' then
  print('Check if file exists...')
  if not fs.exists(args[2]) then
    print('File does not exist, plese, choose correct file.')
    return nil
  end
  print('Start hosting file: '..args[2] .. ' as ' .. args[3])
  lfr.pull(255,false,{[args[3]]=args[2]})
  print('Hosting ended')
elseif args[1] == 'r' then
  print('Check if file exists...')
  if fs.exists(args[2]) then
    print('Output file already exists, want to rewrite it?')
    print('y - confirm \n n - cancel')
    a = io.read()
    if a ~= 'y' then
      print('Cancel request...')
      return nil
    end
  end
  print('Requesting file: ' .. args[3])
  lfr.request(255,args[3],args[2])
  print('Request ended')
end
print('Done!')
