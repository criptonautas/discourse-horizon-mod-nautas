// "Tier [karma]": the member's tier, then their karma this calendar month when
// they have any. Both fields come from Power Tools Nautas on the user card and
// profile payloads (nautas_tier, nautas_monthly_karma).
const format = (score) => score.toLocaleString();

const TierKarma = <template>
  {{#if @user.nautas_tier}}
    <span class="nautas-tier-karma">
      {{@user.nautas_tier}}
      {{#if @user.nautas_monthly_karma}}
        [{{format @user.nautas_monthly_karma}}]
      {{/if}}
    </span>
  {{/if}}
</template>;

export default TierKarma;
