<script>
import WebVM from '$lib/WebVM.svelte';
import * as configObj from '/config_terminal';
import { tryPlausible } from '$lib/plausible.js';
function handleProcessCreated(processCount)
{
	// Log the first 5 processes, to get an idea of the level of interaction from the public
	if(processCount <= 5)
	{
		tryPlausible(`Process started: ${processCount}`);
	}
}
// The block cache holds the visitor's writes on top of the disk image. Key it by
// image name, so a new image (new name) never gets blocks written against an old one.
const cacheId = `blocks_${configObj.diskImageUrl.split('/').pop()}`;
// Drop block caches left over from previous images. CheerpX names an IDBDevice's
// database "cjFS_/<id>/".
async function deleteStaleBlockCaches()
{
	if(typeof indexedDB === "undefined" || !indexedDB.databases)
		return;
	for(const { name } of await indexedDB.databases())
	{
		if(name && name.startsWith("cjFS_/blocks_") && name !== `cjFS_/${cacheId}/`)
			indexedDB.deleteDatabase(name);
	}
}
deleteStaleBlockCaches().catch((e) => console.warn("Could not delete stale block caches", e));
</script>

<WebVM configObj={configObj} processCallback={handleProcessCreated} cacheId={cacheId} />
