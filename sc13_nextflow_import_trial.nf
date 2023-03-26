#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {TRIMMOMATIC} from './sc11_nextflow_trimmomatic2.nf'
// include {trim_pathnames} from './sc12_nextflow_trimmomatic3.nf'

params.inputdir = "data"
params.output_dir = "analysis/sc10"
params.sampleid = Channel.of("DRR258031", 'SRR21977427')


workflow {
    (input_ch, output_path) = trim_pathnames(params.inputdir, params.output_dir, params.sampleid)
    // input_dir = "${params.inputdir}/${params.sampleid}.fastq.gz".toString()
    // output_dir = "${params.output_dir}/${params.sampleid}_trimmed_2.fastq.gz".toString()
    // input_ch = Channel.fromPath(input_dir)
    // output_path = Channel.fromPath(output_dir)
    
    /*  The script to execute is called by its process name,
    and input is provided between brackets. */
    TRIMMOMATIC(Channel.fromPath(input_ch), Channel.fromPath(output_path))

    /*  Process output is accessed using the `out` channel.
    The channel operator view() is used to print
    process output to the terminal. */
    TRIMMOMATIC.out.view({ "Received: $it" })
}


process trim_pathnames {
    input:
    val inputdir
    val output_dir
    val sampleid

    output:
    path input_ch
    path output_path

    script:
    //  Input data is received through channels
    input_dir = "${inputdir}/${sampleid}.fastq.gz"
    output_dir = "${output_dir}/${sampleid}_trimmed_3.fastq.gz"
    input_ch = Channel.fromPath(input_dir)
    output_path = Channel.fromPath(output_dir)

    """
    printf '\n'
    """
}