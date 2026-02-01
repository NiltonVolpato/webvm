<script>
	export let clickHandler = null;
	export let buttonTooltip = null;
	export let bgColor = "bg-neutral-700";
	export let hoverColor = "hover:bg-neutral-500"
	export let buttonIcon = null;
</script>

<button class="inline-block h-7 {bgColor} text-sm p-1 rounded-md shadow-md shadow-neutral-900 {(clickHandler != null) ? `${hoverColor} cursor-pointer` : ""}" title={buttonTooltip} on:click={clickHandler}>
<span class="w-5 inline-block text-center" style="font-family: 'ZedMono NF', monospace;">{buttonIcon}</span>
</button>
