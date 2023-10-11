-- Copyright (c) 2022, Vi Grey
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
-- LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
-- OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
-- SUCH DAMAGE.

local MAGIC_NUMBER = 0x54415344
local VERSION = 0x0001
local G_KEYLEN = 0x02

local CONSOLE_TYPE = 0x0001 -- Done
local CONSOLE_REGION = 0x0002 -- Done
local ROM_NAME = 0x0004 -- Done
local EMULATOR_NAME = 0x0007 -- Done
local DUMP_CREATED = 0x000b -- Done
local DUMP_LAST_MODIFIED = 0x000c -- Done
local TOTAL_FRAMES = 0x000d -- Done
local RERECORDS = 0x000e -- Done
local MEMORY_INIT = 0x0012 -- Done
local GAME_IDENTIFIER = 0x0013 -- Done
local PORT_CONTROLLER = 0x00f0 -- Done (More to handle later)
local PORT_OVERREAD = 0x00f1 -- Done

local NES_LATCH_FILTER = 0x0101 -- Done
local NES_CLOCK_FILTER = 0x0102 -- Done

local INPUT_CHUNK = 0xfe01 -- Done (More to handle later)
local TRANSITION = 0xfe03 -- Done
local LAG_FRAME_CHUNK = 0xfe04 -- Done

local EXPERIMENTAL = 0xfffe

local NES_STANDARD_CONTROLLER = 0x0101

local moviePlaying = false
local resetValueLast = 0x0000
local afterPowerOn = false
local lagCount = 0
local resetTransitionPackets = ""
local cpuCyclesLastFrame = 0
local region = ""

local tasdFile
local lastController

local nesControls = {"right", "left", "down", "up", "start", "select", "B", "A"}

-- Convert a non negative integer (number) to a byte string of size
-- byteLen.  Returns a blank string if number is too large for byteLen
-- or if number is negative.
function intToBytes(number, byteLen)
  local byteString = ""
  if (number < 0) then
    return byteString
  elseif (number >= (256 ^ byteLen)) then
    return byteString
  end
  for x = byteLen - 1, 0, -1 do
    byteString = byteString .. string.char(math.floor(number / 256 ^ x) % 256)
  end
  return byteString
end

-- Get exponent of number
function getExponent(number)
  return math.ceil(math.log(number + 1)/math.log(256))
end

-- Create a packet byte string
function makePacket(packetKey, packetPayload)
  local packetString = intToBytes(packetKey, G_KEYLEN)
  if packetString == "" then
    return packetString
  end
  local packetPayloadLen = string.len(packetPayload)
  local packetPayloadLenExponent = getExponent(packetPayloadLen)
  packetString = packetString .. intToBytes(packetPayloadLenExponent, 1)
  packetString = packetString .. intToBytes(packetPayloadLen, packetPayloadLenExponent)
  packetString = packetString .. packetPayload
  return packetString
end

function getConsoleTypePacket()
  local packetPayload = intToBytes(0x01, 1)
  return makePacket(CONSOLE_TYPE, packetPayload)
end

function getConsoleRegionPacket()
  local regionNumber = 3
  if (region == "NTSC") then
    regionNumber = 1
  elseif (region == "PAL") then
    regionNumber = 2
  end
  local packetPayload = intToBytes(regionNumber, 1)
  return makePacket(CONSOLE_REGION, packetPayload)
end

function getROMNamePacket()
  local packetPayload = rom.getfilename() .. ".nes"
  return makePacket(ROM_NAME, packetPayload)
end

function getMemoryInitPacket(dataType, device, required, name, data)
  local packetPayload = intToBytes(dataType, 1)
  packetPayload = packetPayload .. intToBytes(device, 2)
  packetPayload = packetPayload .. intToBytes(required, 1)
  packetPayload = packetPayload .. intToBytes(string.len(name), 1)
  packetPayload = packetPayload .. name
  packetPayload = packetPayload .. data
  return makePacket(MEMORY_INIT, packetPayload)
end

function getGameIdentifierPacket()
  local packetPayload = intToBytes(0x01, 1) -- Type is MD5
  packetPayload = packetPayload .. intToBytes(0x02, 1) -- Encoding is hex
  packetPayload = packetPayload .. intToBytes(0x00, 1) -- NLEN is 0
  packetPayload = packetPayload .. rom.gethash("md5")
  return makePacket(GAME_IDENTIFIER, packetPayload)
end

function getEmulatorNamePacket()
  local packetPayload = "fceux"
  return makePacket(EMULATOR_NAME, packetPayload)
end

function getDumpCreatedPacket(unixTimestamp)
  local packetPayload = intToBytes(unixTimestamp, 8)
  return makePacket(DUMP_CREATED, packetPayload)
end

function getDumpLastModifiedPacket(unixTimestamp)
  local packetPayload = intToBytes(unixTimestamp, 8)
  return makePacket(DUMP_LAST_MODIFIED, packetPayload)
end

function getTotalFramesPacket()
  local packetPayload = intToBytes(movie.length(), 4)
  return makePacket(TOTAL_FRAMES, packetPayload)
end

function getRerecordsPacket()
  local packetPayload = intToBytes(movie.rerecordcount(), 4)
  return makePacket(RERECORDS, packetPayload)
end

-- Only supports standard controllers at the moment
function getPortControllerPacket(playerCount, controllerType)
  local finishedPackets = ""
  for x = 1, playerCount, 1 do
    local packetPayload = intToBytes(x, 1)
    packetPayload = packetPayload .. intToBytes(controllerType, 2)
    finishedPackets = finishedPackets .. makePacket(PORT_CONTROLLER, packetPayload)
  end
  return finishedPackets
end

function getPortOverreadPacket(playerCount, controllerType)
  local finishedPackets = ""
  for x = 1, playerCount, 1 do
    local packetPayload = intToBytes(x, 1)
  	packetPayload = packetPayload .. intToBytes(0x00, 1)
    finishedPackets = finishedPackets .. makePacket(PORT_OVERREAD, packetPayload)
  end
  return finishedPackets
end


function getNESLatchFilterPacket()
  local packetPayload = intToBytes(8000, 2)
  return makePacket(NES_LATCH_FILTER, packetPayload)
end

function getNESClockFilterPacket()
  local packetPayload = intToBytes(10, 1)
  return makePacket(NES_CLOCK_FILTER, packetPayload)
end

function getInputChunkPacket(player, inputs, controllerType)
  local payloadLen = 1
  if (controllerType == NES_STANDARD_CONTROLLER) then
    payloadLen = 1
  end
  local packetPayload = intToBytes(player, 1)
  packetPayload = packetPayload .. intToBytes(inputs, payloadLen)
  return makePacket(INPUT_CHUNK, packetPayload)
end

function getLagFrameChunkPacket()
  local packetPayload = intToBytes(movie.framecount() - lagCount, 4)
  packetPayload = packetPayload .. intToBytes(lagCount, 4)
  return makePacket(LAG_FRAME_CHUNK, packetPayload)
end

function getTransitionPacket()
  local packetPayload = intToBytes(0x01, 1)
  packetPayload = packetPayload .. intToBytes(0x00, 1)
  packetPayload = packetPayload .. intToBytes(movie.framecount(), 8)
  packetPayload = packetPayload .. intToBytes(0x01, 1)
  return makePacket(TRANSITION, packetPayload)
end

function getExperimentalPacket()
  local packetPayload = intToBytes(0x01, 1)
  return makePacket(EXPERIMENTAL, packetPayload)
end

-- Get TASD file header (currently TASD\x00\x01\x02)
function getTASDFileHeader()
  local header = intToBytes(MAGIC_NUMBER, 4)
  header = header .. intToBytes(VERSION, 2)
  header = header .. intToBytes(G_KEYLEN, 1)
  return header
end

-- Begin dump by creating TASD file, writing initial data to it,
--   setting the emulator speed to maximum, and starting the movie
function startDump()
  -- Movie has not been started since the lua script started
  setupTASDFile()
  tasdFile:write(getTASDFileHeader())
  tasdFile:write(getExperimentalPacket())
  tasdFile:write(getConsoleTypePacket())
  tasdFile:write(getROMNamePacket())
  tasdFile:write(getGameIdentifierPacket())
  tasdFile:write(getEmulatorNamePacket())
  tasdFile:write(getTotalFramesPacket())
  tasdFile:write(getRerecordsPacket())
  tasdFile:write(getPortControllerPacket(2, NES_STANDARD_CONTROLLER))
  tasdFile:write(getPortOverreadPacket(2))
  tasdFile:write(getNESLatchFilterPacket())
  tasdFile:write(getNESClockFilterPacket())
  -- Rest CPU cycle count to 0
  debugger.resetcyclescount()
  movie.playbeginning()
  emu.pause()
  -- Get CPU RAM and store it in TASD file
  storeInitialCPURAM()
  -- Get Cartridge Save RAM and store it in TASD file
  storeInitialSaveData()
  emu.unpause()
  moviePlaying = true
  print("Starting movie.\n")
  print("Replay (TASD) file will not be finished writing until the movie is " ..
        "finished.\n")
  emu.speedmode("maximum")
  setResetCallback()
end

-- Set and update execution callback for when the 16-bit big-endian
--  address stored at 0xfffc-0xfffd is executed.  This function is
--  called frequently because some NES cartridge mappers allow the
--  data at 0xfffc-0xfffd to be changed.
function setResetCallback()
  resetValue = memory.readbyteunsigned(0xfffd) * 256
  resetValue = resetValue + memory.readbyteunsigned(0xfffc)
  if (resetValue ~= resetValueLast) then
    -- Value at reset vector (0xfffc-0xfffd) has changed
    unsetResetCallback()
    memory.registerexec(resetValue, detectReset)
    resetValueLast = resetValue
  end
end

-- Unset the execution callback for when the 16-bit big-endian address
--  stored at 0xfffc-0xfffd is executed.
function unsetResetCallback()
  memory.registerexec(resetValueLast, nil)
end

-- Add console reset to list of reset transition packets.  Ignores the
--   first detected RESET, as the initial console power-on triggers
--   this function as well
function detectReset()
  if (afterPowerOn) then
    resetTransitionPackets = resetTransitionPackets .. getTransitionPacket()
  end
  afterPowerOn = true
end

-- Some cleanup after the movie has closed, including setting the
--   emulator speed back to normal
function finishMovie()
  emu.speedmode("normal")
  unsetResetCallback()
  moviePlaying = false
  movie.close()
  emu.registerafter(nil)
  print("Movie finished.\n")
end

-- Finish writing the TASD file by writing the DUMP_CREATED,
--   DUMP_LAST_MODIFIED, and CONSOLE_REGION packets and closing the
--   TASD file.
function finishTASDFile()
  local unixTimestamp = os.time(os.date("*t"))
  tasdFile:write(getDumpCreatedPacket(unixTimestamp))
  tasdFile:write(getDumpLastModifiedPacket(unixTimestamp))
  tasdFile:write(getConsoleRegionPacket())
  tasdFile:close()
  print("Replay (TASD) file finished.\n")
end

-- Converts frame input for players 1 and 2 to an INPUT_CHUNK packet
--   and writes the INPUT_CHUNK packet to the TASD file
function handleInputs()
  for i = 1, 2, 1 do
    local controls = joypad.get(i)
    local controllerInput = 0xff
    for x = 1, #nesControls do
      if (controls[nesControls[x]]) then
        controllerInput = bit.bxor(controllerInput, bit.lshift(1, x - 1))
      end
    end
    tasdFile:write(getInputChunkPacket(i, controllerInput, NES_STANDARD_CONTROLLER))
  end
end

-- Single frame handling code.  Also determines the NES console's
--   region based on the amount of CPU cycles between 2 adjacent
--   frames.
function handleFrame()
  if (region == "") then
    local cpuCyclesNow = debugger.getcyclescount()
    local cpuCyclesDif = cpuCyclesNow - cpuCyclesLastFrame
    cyclesLastFrame = cpuCyclesNow
    if (cpuCyclesDif < 36000 and cpuCyclesDif > 29000) then
      if (cpuCyclesDif < 31000) then
        -- Region is NTSC (~29780.5 cycles per frame)
        region = "NTSC"
      elseif (cpuCyclesDif > 34000) then
        -- Region is Dendy (~35464 cycles per frame)
        region = "Dendy"
      else
        -- Region is PAL (~33247.5 cycles per frame)
        region = "PAL"
      end
    end
  else
  end
  if (emu.lagged()) then
    lagCount = lagCount + 1
  else
    if (lagCount > 0) then
      tasdFile:write(getLagFrameChunkPacket())
    end
    lagCount = 0
    handleInputs()
  end
end


-- Create TASD File from ROM file name
function setupTASDFile()
  local fileName = movie.name():match("(.+)%..+$")
  local tasdFileName = fileName .. ".tasd"
  tasdFile = io.open(tasdFileName, "wb+")
  print("Created replay (TASD) file " .. tasdFileName .. "\n")
end

-- Store initial CPU RAM (0x0000 - 0x07FF) in TASD file
function storeInitialCPURAM()
  print("Storing initial CPU RAM")
  local cpuRAMData = ""
  for i = 0x0000, 0x07ff, 1 do
    cpuRAMData = cpuRAMData .. string.char(memory.readbyte(i))
  end
  tasdFile:write(getMemoryInitPacket(0xff, 0x0101, 0, "", cpuRAMData))
  print("Finished storing initial CPU RAM\n")
end

-- Store initial cartridge save data (0x6000 - 0x7FFF) in TASD file
function storeInitialSaveData()
  if (bit.band(rom.readbyte(6), 2)) then
    print("Storing initial save data")
    local saveRAMData = ""
    for i = 0x6000, 0x7fff, 1 do
      saveRAMData = saveRAMData .. string.char(memory.readbyte(i))
    end
    tasdFile:write(getMemoryInitPacket(0xff, 0x0102, 0, "", saveRAMData))
    print("Finished storing initial save data\n")
  end
end

-- General handler for dumping TASD file (this of this essentially as
--   the main() function)
function gameHandler()
  if (movie.active()) then
    -- Movie is loaded/active
    if (moviePlaying == false) then
      startDump()
    else
      if (movie.framecount() > movie.length()) then
        -- End of movie
        finishTASDFile()
        finishMovie()
        print("If you wish to dump another TAS, you will need to run this script again\n")
      elseif (movie.framecount() > 1) then
        setResetCallback()
        handleFrame()
        -- End of frame
        tasdFile:write(resetTransitionPackets)
        resetTransitionPackets = ""
      end
    end
  elseif (moviePlaying == true) then
    -- Error handling movie
    finishMovie()
    print("Error handling movie.  Try playing the movie again.\n")
  end
end

if (movie.active() == false) then
  print("Select a movie file\n")
end

emu.registerafter(gameHandler)

