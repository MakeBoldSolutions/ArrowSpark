interface ImportMetaEnv {
  /** Base URL of the reactions API, e.g. https://makeboldspark.com. Unset means "unreachable". */
  readonly PUBLIC_REACTIONS_URL?: string;
  /** Build id of the exported game; the Play page frames /game/<id>/index.html. */
  readonly PUBLIC_GAME_BUILD?: string;
  /** "true" after the showcase closes: reaction forms are replaced and local queues cleared. */
  readonly PUBLIC_FEEDBACK_CLOSED?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
