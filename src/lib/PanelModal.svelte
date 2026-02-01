<script>
	import { createEventDispatcher } from 'svelte';
	import NetworkingTab from './NetworkingTab.svelte';
	import AnthropicTab from './AnthropicTab.svelte';
	import CpuTab from './CpuTab.svelte';
	import DiskTab from './DiskTab.svelte';

	export let activePanel = null; // 'network' | 'claude' | 'cpu' | 'disk' | null
	export let handleTool = null;

	const dispatch = createEventDispatcher();

	function close() {
		dispatch('close');
	}

	function handleKeydown(event) {
		if (event.key === 'Escape') {
			close();
		}
	}

	function handleBackdropClick(event) {
		if (event.target === event.currentTarget) {
			close();
		}
	}

	const panelTitles = {
		network: 'Networking',
		claude: 'Claude AI',
		cpu: 'CPU Activity',
		disk: 'Disk'
	};

	const closeIcon = '\u{f00d}'; // nf-fa-close
</script>

<svelte:window on:keydown={handleKeydown} />

{#if activePanel}
	<div
		class="absolute inset-0 flex items-center justify-center bg-black/60 z-50"
		on:click={handleBackdropClick}
		role="dialog"
		aria-modal="true"
		aria-labelledby="panel-title"
	>
		<div class="bg-neutral-700 rounded-lg shadow-2xl max-w-lg w-full mx-4 max-h-[80vh] flex flex-col">
			<!-- Header -->
			<div class="flex items-center justify-between px-4 py-3 border-b border-neutral-600">
				<h2 id="panel-title" class="text-lg font-semibold text-gray-100">
					{panelTitles[activePanel] || activePanel}
				</h2>
				<button
					class="text-gray-400 hover:text-white transition-colors p-1"
					on:click={close}
					aria-label="Close panel"
				>
					<span style="font-family: 'ZedMono NF', monospace;">{closeIcon}</span>
				</button>
			</div>

			<!-- Content -->
			<div class="p-4 overflow-y-auto flex-1 text-gray-100">
				{#if activePanel === 'network'}
					<NetworkingTab on:connect />
				{:else if activePanel === 'claude'}
					<AnthropicTab {handleTool} />
				{:else if activePanel === 'cpu'}
					<CpuTab />
				{:else if activePanel === 'disk'}
					<DiskTab on:reset />
				{/if}
			</div>
		</div>
	</div>
{/if}
