import { themePrefix } from "virtual:theme";
import { or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

// BTCPay Point of Sale in an iframe; sized in scss/btcpay-pos.scss.
// <BtcpayPos /> loads the POS mapped to the BTCPay root; @src picks another app.
const BtcpayPos = <template>
  <iframe
    class="btcpay-pos"
    src={{or @src "https://pay.criptonautas.co/"}}
    title={{i18n (themePrefix "btcpay_pos.title")}}
    allow="clipboard-write; payment"
    loading="lazy"
  ></iframe>
</template>;

export default BtcpayPos;
