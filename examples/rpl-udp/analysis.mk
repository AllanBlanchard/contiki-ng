# For Frama-C #################################################################
ifeq ($(SUB), client)
  FC_PROJECT_FILES=udp-client.c
endif
ifeq ($(SUB), server)
  FC_PROJECT_FILES=udp-server.c
endif
###############################################################################
