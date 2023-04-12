version 1.1

task setoff_multiqc_processing_v1 {
    meta {
        developer: "Rachel Duffin"
        date: "27/08/2021"
        version: "1.0"
    }
    input{
        String project_name
        String sambamba_coverage_level
        Array[File?] depends_on
    }
    Int num_analyses = length(depends_on)

    command <<<
        set -exo pipefail
        API_KEY=tsN9cklrUfUlB1CuHqVOw7ZAqnuDzYE4

        # Override app variables so the dx run commands can be run in the project
        unset DX_WORKSPACE_ID
        dx cd "$DX_PROJECT_CONTEXT_ID"
        source ~/.dnanexus_config/unsetenv
        dx clearenv
        dx login --noprojects --token "$API_KEY"
        dx select ~{project_name}

        workflow_cmd="dx run -y \
                        project-G76q9bQ0PXfP7q972fVf2X19:/workflows/multiqc_workflow/multiqc_workflow_v1/multiqc_workflow_v1 \
                        -iproject_name=~{project_name} \
                        -isambamba_coverage_level=~{sambamba_coverage_level} \
                        --project=~{project_name} \
                        --detach \
                        --brief \
                        --ignore-reuse \
                        --auth-token $API_KEY"

        echo "$workflow_cmd"

        # If analysis IDs input to the app, collect them into a dependency string for input into the workflow command. Else do not run the workflow
        if [[ ~{num_analyses} == 0 ]]
        then
            echo "The depends_on input is empty. Therefore the TSO workflow has not been set off. Please troubleshoot."
        else
            echo "The depends_on input contains analysis ID files as expected"

            depends_str=''
            depends_arr=~{sep(",", depends_on)}  # Read in analysis ids into array

            # Create dependency string from analysis ids within file
            for file in "${depends_arr[@]}"; do 
                depends_id="$(<"$file")" # Get analysis id for dependency string from file contents
                echo "$depends_id"

                # Wait until the analysis state changes from in_progress
                state_cmd="dx describe $depends_id --json | jq -r .state"
                echo "$state_cmd"
                
                until $(eval $state_cmd) ! = 'in_progress' do
                    sleep 5
                done
                # Cause app to fail if the analysis state is not done (meaning it is in a failed / partially_failed / terminating / terminated Fstate_cstate)
                # Because we only want to setoff the multiqc workflow if all analyses have succesfully completed
                # This can be setup more gracefully in future by updating the MultiQC app to take file inputs
                if [[ $(eval $state_cmd) =! 'done' ]] ;  
                    exit 1

                # Append to dependency string
                depends_str="${depends_str} -d ${depends_id}"                 
            done

            workflow_cmd_with_depends="$workflow_cmd $depends_str"
            echo "$workflow_cmd_with_depends" > multiqc_workflow_dx_run_cmd.txt

            analysis_id=$($workflow_cmd_with_depends)  # Run workflow and collect id
            echo "$analysis_id" > multiqc_workflow_analysis_id.txt
        fi
    >>>

    output {
        File analysis_id ="multiqc_workflow_analysis_id.txt"
        File dx_run_cmd = "multiqc_workflow_dx_run_cmd.txt"
        File depends_str = "depends_string.txt"
        }
}