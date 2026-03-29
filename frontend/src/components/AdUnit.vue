<template>
  <div class="ad-container">
    <ins 
      class="adsbygoogle"
      :style="adStyle"
      :data-ad-client="adClient"
      :data-ad-slot="adSlot"
      :data-ad-format="format"
      :data-full-width-responsive="responsive"
    ></ins>
  </div>
</template>

<script setup>
import { onMounted, computed } from 'vue'

const props = defineProps({
  position: {
    type: String,
    default: 'sidebar',
    validator: (value) => ['sidebar', 'footer', 'banner'].includes(value)
  },
  format: {
    type: String,
    default: 'auto'
  }
})

// Google AdSense設定
const adClient = 'ca-pub-XXXXXXXXXXXXXXXX' // 後でAdSenseから取得
const adSlots = {
  sidebar: 'XXXXXXXXXX',
  footer: 'XXXXXXXXXX',
  banner: 'XXXXXXXXXX'
}

const adSlot = computed(() => adSlots[props.position] || adSlots.sidebar)

const adStyle = computed(() => {
  const styles = {
    sidebar: 'display:block; min-width:300px; min-height:250px;',
    footer: 'display:block; min-width:728px; min-height:90px;',
    banner: 'display:block; width:100%; height:auto;'
  }
  return styles[props.position] || styles.sidebar
})

const responsive = computed(() => props.position === 'banner' ? 'true' : 'false')

onMounted(() => {
  // AdSenseスクリプトが読み込まれている場合のみ実行
  if (window.adsbygoogle) {
    try {
      (window.adsbygoogle = window.adsbygoogle || []).push({})
    } catch (e) {
      console.error('AdSense error:', e)
    }
  }
})
</script>

<style scoped>
.ad-container {
  margin: 16px 0;
  text-align: center;
  background: #f5f5f5;
  border-radius: 4px;
  padding: 8px;
}

.ad-container ins {
  display: block;
  margin: 0 auto;
}

/* モバイル対応 */
@media (max-width: 768px) {
  .ad-container {
    margin: 8px 0;
    padding: 4px;
  }
}
</style>
