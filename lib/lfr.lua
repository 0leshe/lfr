local cmp = require('component')
local event = require('event')
local toend = {}
local fs = require('filesystem')
if cmp.isAvailable('modem') == false then
  print('lib cant work with this goofy aah computer without modem card.')
  iam = false
else
  iam = true modem = cmp.modem
end
if iam == true then
  function toend.pull(port,forever,database)
    modem.open(port)
    if not forever then
      forever = false
    end
    while true do
      _,_,shitboy,_,_,what = event.pull(math.huge,'modem_message')
      filepath = database[what] or '/huinya a ne path'
      if fs.exists(filepath) == false then 
        modem.broadcast(port,'file does not exists') 
      else
      file = fs.open(filepath,'r')
      packetsize = math.ceil(fs.size(filepath)/8192)
      modem.broadcast(port,'start sending')
      i = 0 isnext = ''
      while true do
        i = i + 1
        if isnext == 'abort' then break end
        if i > packetsize then break end
        local part = file:read(8192)
        modem.broadcast(port,part)
        while true do
        addrs = ''
        isnext = ''
        _,_,addrs,_,_,isnext = event.pull(math.huge,'modem_message')
          if addrs == shitboy then
            if isnext == 'next' then 
              break
            elseif isnext == 'abort' then
              break
            elseif isnext == 'miss' then
              modem.broadcast(port,part)
            end
          end
        end
      end
      file:close()
      modem.broadcast(port,'end sending') end
      if not forever then break end
    end
    modem.close(port)
    return true
  end
  function toend.loadDir(path)
    a = fs.list(path) otend = {} s = '' s = a()
    otend.rename = toend.rename
    otend.copy = toend.copy
    while s ~= nil do
      otend[fs.name(s):match("(.+)%..+") or fs.name(s)] = path ..'/' .. s
      s = nil
      s = a()
    end
    return otend
  end
  function toend.copy(whattable,what,to)
    whattable[to] = whattable[what]
    return whattable,true
  end
  function toend.rename(whattable,what,to)
    if not whattable[what] then return false,'Index not exists' end
    tmp = whattable[what]
    whattable[what] = nil
    whattable[to] = tmp
    return whattable, true
  end
  function toend.request(port,what,towhere,everytime)
    modem.open(port)
    modem.broadcast(port,what)
    while true do 
      _,_, shitboy,_,_,ifstart = event.pull(math.huge,'modem_message') 
      if ifstart == 'start sending' then 
        break 
      elseif ifstart == 'file does not exists' then  
        return false,'failed transfer', ifstart
      end 
    end
    file = fs.open(towhere,'w')
    while true do
      part = nil
      _, _,addrs,_,_,part = event.pull(1,'modem_message')
      if addrs == shitboy then
        if part == 'end sending' then
          break
        elseif part == nil then
          modem.send(shitboy,port,'miss')
        else
          pcall(function(part) everytime(part) end)
          file:write(part)
          modem.send(shitboy,port,'next')
        end
      end
    end
    file:close()
    modem.close(port)
    return true, 'succes transfer', towhere
  end
end
return toend
