import json, sqlite3, urllib.request, urllib.parse, time, uuid, pathlib, sys
DB=r'C:\ProgramData\Jellyfin\Server\data\jellyfin.db'
BASE='http://127.0.0.1:8096'
ROOT=pathlib.Path(r'C:\EQi12_Power_Evidence')
ROOT.mkdir(parents=True,exist_ok=True)
db=sqlite3.connect(f'file:{DB}?mode=ro',uri=True)
row=db.execute("select AccessToken,UserId from Devices order by DateLastActivity desc limit 1").fetchone()
if not row: raise SystemExit('NO_TEST_TOKEN')
token,user_id=row[0],row[1].replace('-','')
headers={'X-Emby-Token':token,'User-Agent':'EQi12-Power-Test/1.0'}
req=urllib.request.Request(BASE+f'/Users/{user_id}/Items?Recursive=true&Fields=Path,MediaSources&IncludeItemTypes=Movie,Video&Limit=1000',headers=headers)
items=json.load(urllib.request.urlopen(req,timeout=30)).get('Items',[])
item=next((x for x in items if 'PLAY_THIS_5MIN_4K60_QSV_TEST' in (x.get('Name') or '')),None)
if not item: raise SystemExit('TEST_ITEM_NOT_FOUND')
item_id=item['Id']; source_id=(item.get('MediaSources') or [{'Id':item_id}])[0].get('Id',item_id)
video_bitrate=9_950_000+(uuid.uuid4().int%100_000)
params={
 'Static':'false','MediaSourceId':source_id,'DeviceId':'EQi12-Power-Test',
 'PlaySessionId':uuid.uuid4().hex,'VideoCodec':'h264','AudioCodec':'aac',
 'VideoBitrate':str(video_bitrate),'AudioBitrate':'128000','MaxWidth':'1920','MaxHeight':'1080',
 'MaxFramerate':'60','TranscodingContainer':'mp4','api_key':token
}
url=BASE+f'/Videos/{item_id}/stream.mp4?'+urllib.parse.urlencode(params)
log=ROOT/'JELLYFIN_POWER_CLIENT.log'
with log.open('w',encoding='utf-8') as f:
 f.write(f'Start={time.strftime("%Y-%m-%d %H:%M:%S")}\nItem={item.get("Name")}\nItemId={item_id}\nTarget=1920x1080 H264 approximately 10Mbps\nVideoBitrate={video_bitrate}\nMode=real-time-throttled-client\n')
 f.flush()
 try:
  with urllib.request.urlopen(urllib.request.Request(url,headers=headers),timeout=60) as r:
   f.write(f'HTTP={r.status} ContentType={r.headers.get("Content-Type")}\n');f.flush()
   start=time.time(); total=0
   while time.time()-start<600:
    b=r.read(1024*1024)
    if not b: break
    total+=len(b)
    # Consume at roughly the requested 10 Mbps playback rate so Jellyfin/FFmpeg
    # does not run the whole file faster than a real client would watch it.
    target_elapsed=total/1_250_000.0
    if target_elapsed>(time.time()-start): time.sleep(target_elapsed-(time.time()-start))
    if int(time.time()-start)%10==0:
     f.write(f'Elapsed={time.time()-start:.1f}s Bytes={total}\n');f.flush()
   f.write(f'End={time.strftime("%Y-%m-%d %H:%M:%S")} Elapsed={time.time()-start:.1f}s Bytes={total}\n')
 except Exception as e:
  f.write(f'ERROR={type(e).__name__}: {e}\n');f.flush();raise
