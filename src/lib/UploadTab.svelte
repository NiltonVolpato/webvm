<script>
    import PanelButton from './PanelButton.svelte';

    export let onUpload = null;

    let state = 'idle'; // idle | selected | uploading | done | error
    let selectedFile = null;
    let progress = 0;
    let errorMessage = '';
    let fileInput;

    const fileIcon = '\u{f4a5}'; // nf-oct-file
    const uploadIcon = '\u{f40a}\u{00a0}'; // nf-oct-upload
    const checkIcon = '\u{f00c}'; // nf-fa-check
    const retryIcon = '\u{f021}'; // nf-fa-refresh

    function handleSelectClick() {
        fileInput?.click();
    }

    function handleFileChange(event) {
        const file = event.target.files?.[0];
        if (file) {
            selectedFile = file;
            state = 'selected';
        }
        event.target.value = '';
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    }

    async function handleUploadClick() {
        if (!selectedFile || !onUpload) return;
        state = 'uploading';
        progress = 0;

        try {
            const content = await new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onprogress = (e) => {
                    if (e.lengthComputable) {
                        progress = Math.round((e.loaded / e.total) * 100);
                    }
                };
                reader.onload = () => resolve(reader.result);
                reader.onerror = () => reject(reader.error);
                reader.readAsArrayBuffer(selectedFile);
            });

            progress = 100;
            await onUpload(selectedFile.name, content);
            state = 'done';
        } catch (e) {
            console.error('Upload failed:', e);
            errorMessage = e.message || 'Upload failed';
            state = 'error';
        }
    }

    function reset() {
        state = 'idle';
        selectedFile = null;
        progress = 0;
        errorMessage = '';
    }
</script>

{#if state === 'idle' || state === 'selected'}
    <ol class="text-sm text-gray-300 mb-4 list-decimal list-inside space-y-1">
        <li>Choose the file you want to upload to the VM.</li>
        <li>Press <span class="font-semibold text-gray-100">Upload</span>.</li>
        <li>The file will appear in <code class="text-amber-400">/data</code> (transient storage).</li>
    </ol>

    {#if state === 'idle'}
        <PanelButton
            buttonIcon={fileIcon}
            clickHandler={handleSelectClick}
            buttonText="Select file"
        />
    {:else}
    <PanelButton
        buttonIcon={fileIcon}
        clickHandler={handleSelectClick}
        buttonText="{selectedFile.name} ({formatSize(selectedFile.size)})"
    />
    <div class="mt-3">
        <PanelButton
            buttonIcon={uploadIcon}
            clickHandler={handleUploadClick}
            buttonText="Upload"
        />
    </div>
    {/if}
{:else if state === 'uploading'}
    <p class="text-sm text-gray-300 mb-2">
        Uploading {selectedFile.name}...
    </p>
    <div class="w-full bg-neutral-600 rounded-full h-3">
        <div
            class="bg-amber-400 h-3 rounded-full transition-all duration-150"
            style="width: {progress}%"
        ></div>
    </div>
    <p class="text-sm text-gray-400 mt-1">{progress}%</p>
{:else if state === 'done'}
    <PanelButton
        buttonIcon={checkIcon}
        buttonText="{selectedFile.name} uploaded"
        bgColor="bg-green-900"
    />
    <p class="text-sm text-gray-300 mt-2">
        File available at <code class="text-amber-400">/data/{selectedFile.name}</code>
    </p>
    <div class="mt-3">
        <PanelButton
            buttonIcon={retryIcon}
            clickHandler={reset}
            buttonText="Upload another"
        />
    </div>
{:else if state === 'error'}
    <p class="text-red-400 text-sm mb-3">{errorMessage}</p>
    <PanelButton
        buttonIcon={retryIcon}
        clickHandler={reset}
        buttonText="Try again"
        bgColor="bg-red-900"
        hoverColor="hover:bg-red-700"
    />
{/if}

<input
    type="file"
    bind:this={fileInput}
    on:change={handleFileChange}
    class="hidden"
/>
