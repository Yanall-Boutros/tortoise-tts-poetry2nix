# TorToiSe

Tortoise is a text-to-speech program built with the following priorities:

1. Strong multi-voice capabilities.
2. Highly realistic prosody and intonation.
   
This repo contains all the code needed to run Tortoise TTS in inference mode.

Manuscript: https://arxiv.org/abs/2305.07243
## Hugging Face space

A live demo is hosted on Hugging Face Spaces. If you'd like to avoid a queue, please duplicate the Space and add a GPU. Please note that CPU-only spaces do not work for this demo.

https://huggingface.co/spaces/Manmay/tortoise-tts

## Install via Nix
```bash
nix develop --impure .
```

## What's in a name?

I'm naming my speech-related repos after Mojave desert flora and fauna. Tortoise is a bit tongue in cheek: this model
is insanely slow. It leverages both an autoregressive decoder **and** a diffusion decoder; both known for their low
sampling rates. On a K80, expect to generate a medium sized sentence every 2 minutes.

well..... not so slow anymore now we can get a **0.25-0.3 RTF** on 4GB vram and with streaming we can get < **500 ms** latency !!! 

## Demos

See [this page](http://nonint.com/static/tortoise_v2_examples.html) for a large list of example outputs.

A cool application of Tortoise + GPT-3 (not affiliated with this repository): https://twitter.com/lexman_ai. Unfortunately, this project seems no longer to be active.

## Usage guide

### Local installation
This flake was built with NixOS. If the flake.nix and flake.lock are in the tortoise-tts github repo, running `enter_nix_development_shell.sh` should set everything up
If you want to use this on your own computer, you must have an NVIDIA GPU.

Be aware that DeepSpeed is disabled on Apple Silicon since it does not work. The flag `--use_deepspeed` is ignored.
You may need to prepend `PYTORCH_ENABLE_MPS_FALLBACK=1` to the commands below to make them work since MPS does not support all the operations in Pytorch.


### do_tts.py

This script allows you to speak a single phrase with one or more voices.
```shell
python tortoise/do_tts.py --text "I'm going to speak this" --voice random --preset fast
```
### faster inference read.py

This script provides tools for reading large amounts of text.

```shell
python tortoise/read_fast.py --textfile <your text to be read> --voice random
```

### read.py

This script provides tools for reading large amounts of text.

```shell
python tortoise/read.py --textfile <your text to be read> --voice random
```

This will break up the textfile into sentences, and then convert them to speech one at a time. It will output a series
of spoken clips as they are generated. Once all the clips are generated, it will combine them into a single file and
output that as well.

Sometimes Tortoise screws up an output. You can re-generate any bad clips by re-running `read.py` with the --regenerate
argument.

### API

Tortoise can be used programmatically, like so:

```python
reference_clips = [utils.audio.load_audio(p, 22050) for p in clips_paths]
tts = api.TextToSpeech()
pcm_audio = tts.tts_with_preset("your text here", voice_samples=reference_clips, preset='fast')
```

To use deepspeed:

```python
reference_clips = [utils.audio.load_audio(p, 22050) for p in clips_paths]
tts = api.TextToSpeech(use_deepspeed=True)
pcm_audio = tts.tts_with_preset("your text here", voice_samples=reference_clips, preset='fast')
```

To use kv cache:

```python
reference_clips = [utils.audio.load_audio(p, 22050) for p in clips_paths]
tts = api.TextToSpeech(kv_cache=True)
pcm_audio = tts.tts_with_preset("your text here", voice_samples=reference_clips, preset='fast')
```

To run model in float16:

```python
reference_clips = [utils.audio.load_audio(p, 22050) for p in clips_paths]
tts = api.TextToSpeech(half=True)
pcm_audio = tts.tts_with_preset("your text here", voice_samples=reference_clips, preset='fast')
```
for Faster runs use all three:

```python
reference_clips = [utils.audio.load_audio(p, 22050) for p in clips_paths]
tts = api.TextToSpeech(use_deepspeed=True, kv_cache=True, half=True)
pcm_audio = tts.tts_with_preset("your text here", voice_samples=reference_clips, preset='fast')
```

## Acknowledgements

This project has garnered more praise than I expected. I am standing on the shoulders of giants, though, and I want to
credit a few of the amazing folks in the community that have helped make this happen:

- Hugging Face, who wrote the GPT model and the generate API used by Tortoise, and who hosts the model weights.
- [Ramesh et al](https://arxiv.org/pdf/2102.12092.pdf) who authored the DALLE paper, which is the inspiration behind Tortoise.
- [Nichol and Dhariwal](https://arxiv.org/pdf/2102.09672.pdf) who authored the (revision of) the code that drives the diffusion model.
- [Jang et al](https://arxiv.org/pdf/2106.07889.pdf) who developed and open-sourced univnet, the vocoder this repo uses.
- [Kim and Jung](https://github.com/mindslab-ai/univnet) who implemented univnet pytorch model.
- [lucidrains](https://github.com/lucidrains) who writes awesome open source pytorch models, many of which are used here.
- [Patrick von Platen](https://huggingface.co/patrickvonplaten) whose guides on setting up wav2vec were invaluable to building my dataset.

## Notice

Tortoise was built entirely by the author (James Betker) using their own hardware. Their employer was not involved in any facet of Tortoise's development.

## License

Tortoise TTS is licensed under the Apache 2.0 license.

If you use this repo or the ideas therein for your research, please cite it! A bibtex entree can be found in the right pane on GitHub.
