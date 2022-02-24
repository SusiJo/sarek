process SAMTOOLS_INDEX {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::samtools=1.14" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.14--hb421002_0' :
        'quay.io/biocontainers/samtools:1.14--hb421002_0' }"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.bam",  includeInputs:true), path("*.bai") , optional:true, emit: bam_bai
    tuple val(meta), path("*.bam",  includeInputs:true), path("*.csi") , optional:true, emit: bam_csi
    tuple val(meta), path("*.cram", includeInputs:true), path("*.crai"), optional:true, emit: cram_crai
    path  "versions.yml"                                                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args  ?: ''
    """
    samtools index -@ ${task.cpus-1} $args $input

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}