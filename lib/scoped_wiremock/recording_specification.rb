module ScopedWireMock
  class RecordingSpecification
    attr_reader :journal_mode_override, :recording_directory
    #delegate to recording spec
    def record_to_current_resource_dir?
      @record_to_current_resource_dir
    end

    def enforce_journal_mode_in_scope?
      @enforce_journal_mode_in_scope
    end

    def recording_responses
      @record_to_current_resource_dir=true
      @journal_mode_override=:record
      self
    end

    def recording_responses_to(directory)
      @recording_directory = directory
      @journal_mode_override=:record
      self
    end

    def playing_back_responses
      @record_to_current_resource_dir=true
      @journal_mode_override=:playback
      self
    end

    def playing_back_responses_from(directory)
      @recording_directory = directory
      @journal_mode_override=:playback
      self
    end

    def maps_to_journal_directory(journal_directory)
      @recording_directory=journal_directory
      @record_to_current_resource_dir=false
      @enforce_journal_mode_in_scope=true
      self
    end

    def copy_response_strategy_state(source)
      @journal_mode_override=source.journal_mode_override
      @recording_directory=source.recording_directory
      @enforce_journal_mode_in_scope=source.enforce_journal_mode_in_scope?
      @record_to_current_resource_dir=source.record_to_current_resource_dir?
    end
    def build()
      {'recordToCurrentResourceDir' => @record_to_current_resource_dir,
           'enforceJournalModeInScope' =>  @enforce_journal_mode_in_scope,
            'journalModeOverride' => @journal_mode_override,
            'recordingDirectory' =>  @recording_directory}
    end

  end
end